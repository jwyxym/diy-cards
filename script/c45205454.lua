--馒头蛙
local s,id=GetID()
function s.initial_effect(c)
	--超量召唤
	aux.AddXyzProcedure(c,nil,2,2)
	c:EnableReviveLimit()
	
	--① 取除1个超量素材，从卡组·墓地特召1只「青蛙」怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END+TIMING_BATTLE_START+TIMING_BATTLE_END)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	
	--② 对方发动墓地卡的效果时无效
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+1)
	e2:SetCondition(s.negcon)
	e2:SetTarget(s.negtg)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)
end

--① cost：取除1个超量素材
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_COST) end
	c:RemoveOverlayCard(tp,1,1,REASON_COST)
end

--① 目标过滤：卡组·墓地的「青蛙」怪兽
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x0012) and c:IsType(TYPE_MONSTER)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end

--① 处理
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		local tc=g:GetFirst()
		local pos=Duel.SelectPosition(tp,tc,POS_FACEUP_ATTACK+POS_FACEUP_DEFENSE)
		Duel.SpecialSummon(tc,0,tp,tp,false,false,pos)
	end
end

--② 条件：对方发动墓地的卡的效果
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:GetActivateLocation()==LOCATION_GRAVE and Duel.IsChainNegatable(ev)
end

--② 目标
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end

--② 处理
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateEffect(ev) then
		-- 可以把自己墓地·除外状态的1只2星以下的水族怪兽特殊召唤
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp)
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter2),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
			if #g>0 then
				Duel.BreakEffect()
				Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end

--② 目标过滤：墓地·除外2星以下水族
function s.spfilter2(c,e,tp)
	return c:IsRace(RACE_AQUA) and c:IsLevelBelow(2) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

return s
