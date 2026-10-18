--嘉豪哥布林
local s,id=GetID()
function s.initial_effect(c)
	--超量召唤手续：9星怪兽×2
	aux.AddXyzProcedure(c,nil,9,2)
	c:EnableReviveLimit()

	--① 这张卡不受这张卡以外的卡的效果影响（全抗）
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.efilter)
	c:RegisterEffect(e1)

	--② 可以用表侧守备表示的状态作出攻击，那个场合用守备力当作攻击力进行伤害计算
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DEFENSE_ATTACK)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end

-- 全抗：不受这张卡以外的效果影响
function s.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end

return s
