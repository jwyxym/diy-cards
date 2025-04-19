--人类恶 显现
function c51900205.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,51900205+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c51900205.cost)
	e1:SetTarget(c51900205.target)
	e1:SetOperation(c51900205.activate)
	c:RegisterEffect(e1)
	if not c51900205.global_check then
		c51900205.global_check=true
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge1:SetOperation(c51900205.checkop)
		Duel.RegisterEffect(ge1,0) 
	end
end
function c51900205.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	while tc do 
		if tc:IsCode(51900202) then 
			Duel.RegisterFlagEffect(0,51900205,0,0,1)
			Duel.RegisterFlagEffect(1,51900205,0,0,1) 
		end  
		tc=eg:GetNext()
	end
end
function c51900205.cost(e,tp,eg,ep,ev,re,r,rp,chk)  
	local flag=Duel.GetFlagEffect(tp,51900205) 
	local x=Duel.GetCounter(tp,LOCATION_ONFIELD,LOCATION_ONFIELD,0x1515)
	if Duel.IsEnvironment(51900206) then flag=flag+x end 
	if chk==0 then return flag>=11 end 
	local ct=11-Duel.GetFlagEffect(tp,51900205)
	if ct>0 then 
		Duel.RemoveCounter(tp,LOCATION_ONFIELD,LOCATION_ONFIELD,0x1515,ct,REASON_COST)	
	end 
end
function c51900205.filter(c,e,tp)
	return c:IsCode(51900204) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true)
end
function c51900205.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c51900205.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		Duel.SetChainLimit(c51900205.chainlm)
	end
end
function c51900205.chainlm(e,rp,tp)
	return tp==rp
end
function c51900205.activate(e,tp,eg,ep,ev,re,r,rp) 
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,c51900205.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
	if tc then
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP) 
		tc:CompleteProcedure()
	end
end


