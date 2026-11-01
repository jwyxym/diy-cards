--- c01219001.lua
-- 通常魔法
local s,id,o=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

function s.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
		and c:CheckFusionMaterial(m,nil,chkf)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		local g1=Duel.GetDecktopGroup(tp,5)
		local g2=Duel.GetDecktopGroup(1-tp,5)
		if #g1==0 and #g2==0 then return false end
		local mg=g1:Clone()
		mg:Merge(g2)
		return Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg,nil,chkf)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 翻开自己·对方卡组上面各5张
	local g1=Duel.GetDecktopGroup(tp,5)
	local g2=Duel.GetDecktopGroup(1-tp,5)
	if #g1==0 and #g2==0 then return end
	Duel.ConfirmCards(tp,g1)
	Duel.ConfirmCards(tp,g2)
	local g=g1:Clone()
	g:Merge(g2)

	-- 筛选可融合召唤的怪兽
	local sg=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,g,nil,chkf)
	if #sg==0 then
		s.retdeck(tp,g)
		return
	end

	-- 选1只融合怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=sg:Select(tp,1,1,nil):GetFirst()
	if not tc then
		s.retdeck(tp,g)
		return
	end

	-- 用翻开的卡作为融合素材
	local mat=Duel.SelectFusionMaterial(tp,tc,g,nil,chkf)
	if #mat==0 then
		s.retdeck(tp,g)
		return
	end

	-- 融合召唤
	tc:SetMaterial(mat)
	Duel.SendtoGrave(mat,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
	Duel.BreakEffect()
	Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
	tc:CompleteProcedure()

	-- 剩余的卡处理
	local remain=g:Clone()
	remain:Sub(mat)
	if #remain>0 then
		s.retdeck(tp,remain)
	end
end

-- 剩余卡回卡组：发动者选任意张回卡组最下面，其余回卡组最上面
function s.retdeck(tp,g)
	if #g==0 then return end
	-- 发动者选任意张回卡组最下面
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	Duel.RevealSelectDeckSequence(true)
	local sg=g:FilterSelect(tp,aux.TRUE,0,#g,nil)
	Duel.RevealSelectDeckSequence(false)
	-- 剩余的卡回卡组最上面
	local rg=g:Clone()
	rg:Sub(sg)

	-- 禁用洗牌检查（不手动恢复，让引擎自动处理）
	Duel.DisableShuffleCheck(true)

	-- 先处理回到卡组最下面的卡（逐张 MoveSequence）
	local sc=sg:GetFirst()
	while sc do
		Duel.MoveSequence(sc,SEQ_DECKBOTTOM)
		sc=sg:GetNext()
	end

	-- 再处理回到卡组最上面的卡（逐张 MoveSequence）
	local rc=rg:GetFirst()
	while rc do
		Duel.MoveSequence(rc,SEQ_DECKTOP)
		rc=rg:GetNext()
	end
end
