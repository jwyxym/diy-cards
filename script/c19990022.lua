--
function c19990022.initial_effect(c)
--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCountLimit(1,19990022)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_END_PHASE)
	e1:SetOperation(c19990022.activate)
	c:RegisterEffect(e1)
	if c19990022.counter==nil then
		c19990022.counter=true
		c19990022[0]=0
		c19990022[1]=0
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		e2:SetCode(EVENT_PHASE_START+PHASE_DRAW)
		e2:SetOperation(c19990022.resetcount)
		Duel.RegisterEffect(e2,0)
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		e3:SetCode(EVENT_RELEASE)
		e3:SetOperation(c19990022.addcount)
		Duel.RegisterEffect(e3,0)
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		e4:SetCode(EVENT_REMOVE)
		e4:SetOperation(c19990022.addcount)
		Duel.RegisterEffect(e4,0)
	end
end
function c19990022.resetcount(e,tp,eg,ep,ev,re,r,rp)
	c19990022[0]=0
	c19990022[1]=0
end
function c19990022.addcount(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	while tc do
		if tc:IsPreviousLocation(LOCATION_MZONE) or tc:IsPreviousLocation(LOCATION_PZONE) and tc:IsType(TYPE_MONSTER) and tc:IsPreviousSetCard(0xb29) then
			local p=tc:GetPreviousControler()
			c19990022[p]=c19990022[p]+1
		end
		tc=eg:GetNext()
	end
end
function c19990022.activate(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetOperation(c19990022.droperation)
	Duel.RegisterEffect(e1,tp)
end
function c19990022.droperation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,19990022)
	Duel.Draw(tp,c19990022[tp],REASON_EFFECT)
end

