--毒罪多头蛇
function c19000056.initial_effect(c)
	c:SetUniqueOnField(1,0,19000056)
	c:SetSPSummonOnce(19000056)
	--fusion summon
	c:EnableReviveLimit()
	aux.AddFusionProcFunRep2(c,aux.FilterBoolFunction(Card.IsRace,RACE_REPTILE),2,127,true)
	aux.AddContactFusionProcedure(c,c19000056.cfilter,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,c19000056.sprop(c))
	--cannot fusion material
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	e0:SetValue(1)
	c:RegisterEffect(e0)
	if not c19000056.global_flag then
		c19000056.global_flag=true
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge1:SetOperation(c19000056.regop)
		Duel.RegisterEffect(ge1,0)
	end
end
function c19000056.regop(e,tp,eg,ep,ev,re,r,rp)
	for tc in aux.Next(eg) do
		if tc:IsRace(RACE_REPTILE) and tc:IsLevelAbove(8) then
			Duel.RegisterFlagEffect(tc:GetSummonPlayer(),19000056,0,0,0)
		end
	end
end
function c19000056.mfilter(c,fc)
	local tp=c:GetControler()
	return c:IsRace(RACE_REPTILE) and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and (Duel.GetFlagEffect(1-tp,19000056)>0 or Duel.GetFlagEffect(tp,19000056)>0) and c:IsAbleToDeckOrExtraAsCost()
end
function c19000056.sprop(c)
	return function(g)
				Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
				--spsummon condition
				local ct=g:GetCount()
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_SET_BASE_ATTACK)
				e1:SetReset(RESET_EVENT+0xff0000)
				e1:SetValue(ct*700)
				c:RegisterEffect(e1)
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_SET_BASE_DEFENSE)
				e2:SetReset(RESET_EVENT+0xff0000)
				e2:SetValue(ct*700)
				c:RegisterEffect(e2)
			end
end