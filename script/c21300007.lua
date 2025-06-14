--断汝筋骨
function c21300007.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c) 
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_COIN)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE) 
	e1:SetCountLimit(1,21300007+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c21300007.accon)
	e1:SetTarget(c21300007.actg)
	e1:SetOperation(c21300007.acop)
	c:RegisterEffect(e1)
	--xx
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_LEAVE_FIELD_P)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetOperation(c21300007.xxcheck)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c) 
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE )
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_CUSTOM+21300007)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetRange(LOCATION_GRAVE) 
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c21300007.ddtg)
	e3:SetOperation(c21300007.ddop)
	c:RegisterEffect(e3)
end
function c21300007.accon(e,tp,eg,ep,ev,re,r,rp)
	local a,b=Duel.GetBattleMonster(tp) 
	e:SetLabelObject(a)
	return a and b 
end
function c21300007.actg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
end
function c21300007.acgck(g) 
	return g:GetClassCount(Card.GetRace)==1 
end 
function c21300007.acop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=e:GetLabelObject()
	local cn=Duel.TossCoin(tp,1) 
	if tc:IsRelateToBattle() and tc:IsFaceup() then 
		tc:RegisterFlagEffect(21300007,0,0,0)
		if cn==1 then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL)
			e1:SetValue(-800)
			tc:RegisterEffect(e1)
		elseif cn==0 then  
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL)
			e1:SetValue(800)
			tc:RegisterEffect(e1)
		end
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil) 
		if g:CheckSubGroup(c21300007.acgck,3,3) then 
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
			e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
			e1:SetRange(LOCATION_MZONE) 
			e1:SetValue(1)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL)
			tc:RegisterEffect(e1)
		end 
	end 
end 
function c21300007.xxckfil(c) 
	return c:GetFlagEffect(21300007)~=0 and c:IsReason(REASON_BATTLE)
end 
function c21300007.xxcheck(e,tp,eg,ep,ev,re,r,rp) 
	local g=eg:Filter(c21300007.xxckfil,nil) 
	if g:GetCount()>0 then   
		local tc=g:GetFirst() 
		while tc do 
		tc:ResetFlagEffect(21300007)
		tc=g:GetNext() 
		end 
		Duel.RaiseEvent(g,EVENT_CUSTOM+21300007,e,0,0,tp,0)
	end 
end
function c21300007.ddtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_MZONE,1,nil) end 
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_MZONE) 
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000) 
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		Duel.SetChainLimit(aux.FALSE)
	end
end
function c21300007.xdgfil(c,tc)  
	return c:GetSequence()<5 and math.abs(c:GetSequence()-tc:GetSequence())==1  
end 
function c21300007.ddop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_MZONE,1,1,nil):GetFirst()
	if tc then 
		local dg=Group.FromCards(tc) 
		if tc:GetSequence()<5 then 
			local xdg=Duel.GetMatchingGroup(c21300007.xdgfil,tp,0,LOCATION_MZONE,nil,tc) 
			dg:Merge(xdg) 
		end 
		local x=Duel.Destroy(dg,REASON_EFFECT)  
		Duel.Damage(1-tp,x*1000,REASON_EFFECT)
	end 
end 


