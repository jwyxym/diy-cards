--玛莉亚
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsFaceup),3,99,s.lcheck)
	
	--这张卡不能作为连接召唤的素材
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	
	--对方场上1只暗属性或不死族怪兽也能作为连接素材
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EFFECT_EXTRA_LINK_MATERIAL)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetValue(s.matval)
	c:RegisterEffect(e2)
	
	--④效果：卡名当作「吸血鬼杀手」
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_ADD_CODE)
	e3:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e3:SetValue(80485722)
	c:RegisterEffect(e3)
	
	--①效果：自己·对方回合，对方场上的不死族怪兽全部除外
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_REMOVE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetHintTiming(0,TIMING_MAIN_END+TIMING_BATTLE_START+TIMING_BATTLE_END)
	e4:SetCountLimit(1,id)
	e4:SetTarget(s.rmtg)
	e4:SetOperation(s.rmop)
	c:RegisterEffect(e4)
	
	--②效果：不受对方不死族怪兽效果影响
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_IMMUNE_EFFECT)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetValue(s.efilter)
	c:RegisterEffect(e5)
	
	--③效果：双方从墓地特召的怪兽变成不死族
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetCode(EFFECT_CHANGE_RACE)
	e6:SetRange(LOCATION_MZONE)
	e6:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e6:SetTarget(aux.TargetBoolFunction(Card.IsSummonLocation,LOCATION_GRAVE))
	e6:SetValue(RACE_ZOMBIE)
	c:RegisterEffect(e6)
end

function s.lcheck(g,lc,tp)
	return g:IsExists(Card.IsCode,1,nil,80485722)
end

function s.is_external_exmat(c,lc,mg,tp)
	local le={c:IsHasEffect(EFFECT_EXTRA_LINK_MATERIAL,tp)}
	for _,te in ipairs(le) do
		local h=te:GetHandler()
		if h and not h:IsCode(id) then
			local f=te:GetValue()
			if f then
				local related,valid=f(te,lc,mg,c,tp)
				if related and valid~=false then
					return true
				end
			end
		end
	end
	return false
end

function s.is_opp(mc,lc,mg,tp)
	return mc:IsControler(1-tp) and not s.is_external_exmat(mc,lc,mg,tp)
end

function s.matval(e,lc,mg,c,tp)
	if e:GetHandler()~=lc then return false,nil end
	if not c:IsControler(1-tp) then return false,nil end
	if not (c:IsAttribute(ATTRIBUTE_DARK) or c:IsRace(RACE_ZOMBIE)) then return false,nil end
	if not mg then return true,true end
	if s.is_external_exmat(c,lc,mg,tp) then return true,true end
	if mg:IsExists(s.is_opp,1,c,lc,mg,tp) then return true,false end
	return true,true
end

function s.rmfilter(c)
	return c:IsRace(RACE_ZOMBIE) and c:IsAbleToRemove()
end

function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rmfilter,tp,0,LOCATION_MZONE,1,nil) end
	local g=Duel.GetMatchingGroup(s.rmfilter,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
end

function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.rmfilter,tp,0,LOCATION_MZONE,nil)
	if #g>0 then
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end

function s.efilter(e,te)
	local tc=te:GetOwner()
	return tc and tc:IsRace(RACE_ZOMBIE) and tc:GetControler()~=e:GetHandlerPlayer()
end

return s