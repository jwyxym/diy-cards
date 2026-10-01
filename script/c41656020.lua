-- 蓝堇色彩的信笺
local s,id,o=GetID()
function s.initial_effect(c)
	--link summon（包含蓝堇怪兽的怪兽2只）
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,nil,2,2,s.lcheck)
	--① 特殊召唤成功时，赋予连接区怪兽同卡名的卡「蓝堇」字段
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetOperation(s.codeop)
	c:RegisterEffect(e1)
	--② 墓效
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id+1)
	e3:SetCost(s.thcost)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end

-- 连接素材检查：至少1只是蓝堇怪兽
function s.lcheck(g)
	return g:IsExists(aux.FilterBoolFunction(Card.IsSetCard,0xe96),1,nil)
end

-- ① 赋予字段
function s.codefilter(c,code)
	return c:IsCode(code) and not c:IsSetCard(0xe96)
end
function s.codeop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=c:GetLinkedGroup()
	local cc=g:GetFirst()
	while cc do
		local code=cc:GetCode()
		local cg=Duel.GetMatchingGroup(s.codefilter,tp,
			LOCATION_HAND+LOCATION_DECK+LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_EXTRA,
			LOCATION_HAND+LOCATION_DECK+LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_EXTRA,nil,code)
		local tc2=cg:GetFirst()
		while tc2 do
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(aux.Stringid(id,3))
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_ADD_SETCODE)
			e1:SetProperty(EFFECT_FLAG_CLIENT_HINT+EFFECT_FLAG_SET_AVAILABLE)
			e1:SetRange(LOCATION_HAND+LOCATION_DECK+LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_EXTRA)
			e1:SetValue(0xe96)
			tc2:RegisterEffect(e1)
			tc2=cg:GetNext()
		end
		cc=g:GetNext()
	end
end

-- ② cost：解放自己·对方场上1张蓝堇卡
function s.thcfilter(c)
	return c:IsSetCard(0xe96) and c:IsFaceup()
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thcfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g=Duel.SelectMatchingCard(tp,s.thcfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	local tc=g:GetFirst()
	-- 记录是否为对方场上的怪兽
	if tc:IsPreviousControler(1-tp) and tc:IsType(TYPE_MONSTER) then
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
	Duel.Release(g,REASON_COST)
end

-- ② 检索/特召过滤器
function s.spfilter(c,e,tp)
	return c:IsSetCard(0xe96) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.thfilter(c)
	return c:IsSetCard(0xe96) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 修改：墓地·除外状态的蓝堇怪兽（可特殊召唤）
function s.gyfilter(c,e,tp)
	return c:IsSetCard(0xe96) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local b1=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
		local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
		return b1 or b2
	end
	local b1=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
	local op=aux.SelectFromOptions(tp,
		{b1,aux.Stringid(id,2)},
		{b2,aux.Stringid(id,4)})
	e:SetLabelObject(op)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local op=e:GetLabelObject()
	if op==1 then
		-- 加入手卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	else
		-- 特殊召唤
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 解放了对方场上怪兽的场合：这张卡里侧除外 + 从除外·墓地把1只蓝堇怪兽特殊召唤
	if e:GetLabel()==1 and c:IsRelateToEffect(e) then
		Duel.BreakEffect()
		Duel.Remove(c,POS_FACEDOWN,REASON_EFFECT)
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.gyfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local rg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.gyfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
			if rg:GetCount()>0 then
				Duel.SpecialSummon(rg,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end