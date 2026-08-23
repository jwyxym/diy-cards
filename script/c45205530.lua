--奥利哈刚之神
local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,48179391)
	c:EnableReviveLimit()
	
	--不能通常召唤
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_CANNOT_SUMMON)
	c:RegisterEffect(e0)
	
	--不能盖放
	local e0b=Effect.CreateEffect(c)
	e0b:SetType(EFFECT_TYPE_SINGLE)
	e0b:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0b:SetCode(EFFECT_CANNOT_MSET)
	c:RegisterEffect(e0b)
	
	--不能用其他卡的效果特殊召唤
	local e0c=Effect.CreateEffect(c)
	e0c:SetType(EFFECT_TYPE_SINGLE)
	e0c:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0c:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0c:SetValue(s.splimit)
	c:RegisterEffect(e0c)
	
	--特殊召唤手续：场上·墓地有10张以上「山铜结界」及记述卡，从手卡特召
	local e00=Effect.CreateEffect(c)
	e00:SetType(EFFECT_TYPE_FIELD)
	e00:SetCode(EFFECT_SPSUMMON_PROC)
	e00:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e00:SetRange(LOCATION_HAND)
	e00:SetCondition(s.spcon)
	c:RegisterEffect(e00)
	
	--①效果：特殊召唤不会被无效化
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e1)
	local e1b=Effect.CreateEffect(c)
	e1b:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1b:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1b:SetOperation(s.sumsuc)
	c:RegisterEffect(e1b)
	
	--②效果
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.oricon)
	e2:SetCode(EFFECT_UNRELEASABLE_SUM)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e2b=e2:Clone()
	e2b:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	c:RegisterEffect(e2b)
	
	local e2c=Effect.CreateEffect(c)
	e2c:SetType(EFFECT_TYPE_SINGLE)
	e2c:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2c:SetRange(LOCATION_MZONE)
	e2c:SetCondition(s.oricon)
	e2c:SetCode(EFFECT_IMMUNE_EFFECT)
	e2c:SetValue(s.efilter)
	c:RegisterEffect(e2c)
	
	local e2d=Effect.CreateEffect(c)
	e2d:SetType(EFFECT_TYPE_SINGLE)
	e2d:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2d:SetRange(LOCATION_MZONE)
	e2d:SetCondition(s.oricon)
	e2d:SetCode(EFFECT_UPDATE_ATTACK)
	e2d:SetValue(s.atkval)
	c:RegisterEffect(e2d)
	local e2e=e2d:Clone()
	e2e:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2e)
	
	--③效果：被战斗破坏的场合，受到30000伤害
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_BATTLE_DESTROYED)
	e3:SetCondition(s.damcon)
	e3:SetOperation(s.damop)
	c:RegisterEffect(e3)
end

function s.splimit(e,se,sp,st)
	return se and se:GetHandler():IsCode(id)
end

function s.orifilter(c)
	return c:IsCode(48179391) or aux.IsCodeListed(c,48179391)
end

function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local g1=Duel.GetMatchingGroupCount(s.orifilter,tp,LOCATION_ONFIELD,0,nil)
	local g2=Duel.GetMatchingGroupCount(s.orifilter,tp,LOCATION_GRAVE,0,nil)
	return g1+g2>=10 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end

function s.sumsuc(e,tp,eg,ep,ev,re,r,rp)
	Duel.SetChainLimitTillChainEnd(aux.FALSE)
end

function s.oricon(e)
	return Duel.IsExistingMatchingCard(Card.IsCode,e:GetHandlerPlayer(),LOCATION_FZONE,0,1,nil,48179391)
end

function s.efilter(e,te)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end

function s.atkval(e,c)
	local sum=0
	local g=Duel.GetMatchingGroup(Card.IsFaceup,c:GetControler(),0,LOCATION_MZONE,nil)
	for tc in aux.Next(g) do
		sum=sum+tc:GetAttack()
	end
	return sum
end

function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end

function s.damop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Damage(tp,30000,REASON_EFFECT)
end

return s