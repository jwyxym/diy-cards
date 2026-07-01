--侦探：逻辑推理
--卡密ID: 45205324

local s,id=GetID()

function s.initial_effect(c)
	--发动效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	
	--①效果：融合召唤（双方回合可发）
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetHintTiming(0,TIMING_MAIN_END+TIMING_END_PHASE)
	e2:SetCountLimit(1,id+100)
	e2:SetTarget(s.fusiontg)
	e2:SetOperation(s.fusionop)
	c:RegisterEffect(e2)
	
	--②效果：翻5张并自由排序
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DECKDEST)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_SZONE)
	e3:SetHintTiming(0,TIMING_MAIN_END+TIMING_END_PHASE)
	e3:SetCountLimit(1,id+200)
	e3:SetCondition(s.reasoncon)
	e3:SetTarget(s.reasontg)
	e3:SetOperation(s.reasonop)
	c:RegisterEffect(e3)
end

--==================== ①融合召唤（参考超载融合，支持场上+墓地） ====================
-- 场上素材过滤（可被移除）
function s.filter0(c)
	return c:IsOnField() and c:IsAbleToDeck()
end

-- 场上素材过滤（免疫效果检测）
function s.filter1(c,e)
	return c:IsOnField() and c:IsAbleToDeck() and not c:IsImmuneToEffect(e)
end

-- 墓地素材过滤
function s.filter3(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end

-- 融合怪兽过滤
function s.filter2(c,e,tp,m,f,chkf)
	return c:IsSetCard(0x1D5C) and c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) 
		and c:CheckFusionMaterial(m,nil,chkf)
end

function s.fusiontg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 场上素材
		local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter0,nil)
		-- 墓地素材
		local mg2=Duel.GetMatchingGroup(s.filter3,tp,LOCATION_GRAVE,0,nil)
		mg1:Merge(mg2)
		local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
			end
		end
		return res
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.fusionop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 场上素材（免疫检测）
	local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
	-- 墓地素材
	local mg2=Duel.GetMatchingGroup(s.filter3,tp,LOCATION_GRAVE,0,nil)
	mg1:Merge(mg2)
	
	local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg3=nil
	local sg2=nil
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
	end
	
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 素材返回卡组（参考超载融合是除外，这里是返回卡组）
			Duel.SendtoDeck(mat1,nil,SEQ_DECKSHUFFLE,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			Duel.BreakEffect()
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end

--==================== ②控制牌顶 ====================
function s.reasoncon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_MZONE,0,1,nil,0x1D5C)
end

function s.reasontg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(1-tp,LOCATION_DECK,0)>=5 end
end

function s.reasonop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.GetFieldGroupCount(1-tp,LOCATION_DECK,0)<5 then return end
	
	local g=Duel.GetDecktopGroup(1-tp,5)
	Duel.ConfirmCards(tp,g)
	
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
	Duel.SortDecktop(tp,1-tp,5)
	
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetOperation(s.shuffleop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end

function s.shuffleop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ShuffleDeck(1-tp)
end