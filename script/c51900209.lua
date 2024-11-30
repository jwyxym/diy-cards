--回归的拥抱
function c51900209.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGETT)  
	e1:SetCountLimit(1,51900209)
	e1:SetTarget(c51900209.target)
	e1:SetOperation(c51900209.operation)
	c:RegisterEffect(e1) 
	--token
	local e2=Effect.CreateEffect(c) 
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_QUICK_O) 
	e2:SetCode(EVENT_FREE_CHAIN) 
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,11900209)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c51900209.tktg)
	e2:SetOperation(c51900209.tkop)
	c:RegisterEffect(e2) 
end
function c51900209.ctfil(c,e,tp)
	return c:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK) and c:IsSummonPlayer(1-tp) and c:IsFaceup() and c:IsControlerCanBeChanged() and c:IsCanBeEffectTarget(e)
end 
function c51900209.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc) 
	if chkc then return eg:IsContains(chkc) and c51900209.ctfil(chkc,e,tp) end
	if chk==0 then return eg:Filter(c51900209.ctfil,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local tc=eg:Filter(c51900209.ctfil,nil,e,tp):Select(tp,1,1,nil):GetFirst() 
	Duel.SetTargetCard(tc) 
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,tc:GetBaseAttack())
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,tc,1,0,0)
end
function c51900209.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then 
		Duel.Damage(tp,tc:GetBaseAttack(),REASON_EFFECT)
		Duel.GetControl(tc,tp)
	end
end
function c51900209.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,51900202,nil,TYPES_TOKEN_MONSTER,2000,2000,8,RACE_DRAGON,ATTRIBUTE_DARK) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
end
function c51900209.tkop(e,tp,eg,ep,ev,re,r,rp) 
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,51900202,nil,TYPES_TOKEN_MONSTER,2000,2000,8,RACE_DRAGON,ATTRIBUTE_DARK) then return end
	local token=Duel.CreateToken(tp,51900202)
	if Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP) then 
		local e1=Effect.CreateEffect(c) 
		e1:SetType(EFFECT_TYPE_SINGLE) 
		e1:SetCode(EFFECT_CHANGE_RACE) 
		e1:SetRange(LOCATION_MZONE) 
		e1:SetValue(RACE_DRAGON) 
		e1:SetReset(RESET_EVENT+RESETS_STANDARD) 
		token:RegisterEffect(e1)
		local e1=Effect.CreateEffect(c) 
		e1:SetType(EFFECT_TYPE_SINGLE) 
		e1:SetCode(EFFECT_NONTUNER) 
		e1:SetRange(LOCATION_MZONE) 
		e1:SetValue(function(e,c)
		return e:GetHandler():IsControler(c:GetControler()) end) 
		e1:SetReset(RESET_EVENT+RESETS_STANDARD) 
		token:RegisterEffect(e1)
	end 
	Duel.SpecialSummonComplete()
end

